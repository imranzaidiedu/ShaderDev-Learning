Shader "Unlit/Lighting"
{
    //Lambert-ian  Lighting which is also called diffused lighting 
    
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            //^These are built-in unity code snippets to access unity specific data
            //such as light position which unity populates automaticall

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);//getting the position of the fragment
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float3 N = normalize(i.normal);

                //_WorldSpaceLightPos0
                //According to this documentation https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
                //This light is infinetely far away and that's why it only provides us the direction of it
                //Which means that the w component in this float4 is going to be 0 and for other lights
                //the w component is going to be 1 which means you are getting the actual position and not the direction

                //NOTE: The way that unity works that this pass main pass, the base pass or the pass that this comment is written is
                //always going to be the directional light. You cannot have point light in the base pass
                //Technically, if you want to do it properly, for every additional light, you should be doing it in
                //additional pass for each additional light and those can be either directional lights or point lights
                //So techically, _WorldSpaceLightPos0 is a directional light in this pass

                float3 L = _WorldSpaceLightPos0.xyz; //A directional light

                float3 lambert = saturate(dot(N,L));
                float3 diffusionLight = lambert * _LightColor0.xyz;
                //^this is basic lambert-ian shading/lighting or diffuse lighting
                //For lighting color, we don't need to add intensity as the intensity is encoded into the color itself

                //specular lighting: Phong
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos); //view light
                //float3 R = reflect(-L, N);//usses for Phong
                float3 H = normalize(L + V);
                
                float3 specularLight = saturate(dot(H, N)) * (lambert > 0);//uses for Blinn-Phong

                float specularExponent = exp2(_Gloss * 6) + 2;
                specularLight = pow(specularLight, specularExponent); //Speculat exponent
                
                return float4(specularLight.xxx, 1);
            }
            ENDCG
        }
    }
}
