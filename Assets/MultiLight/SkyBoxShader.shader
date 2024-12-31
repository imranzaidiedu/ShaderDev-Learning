Shader "Unlit/SkyBoxShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU 6.2831855

            struct appdata
            {
                float4 vertex : POSITION;
                float3 viewDir : TEXCOORD0;
            };

            struct v2f
            {
                float3 viewDir : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = v.viewDir;
                return o;
            }

            //We are doing this remapping as we are not using cubemap
            //If the skybox was a cubemap then all we'd need to do is use a texture sampler
            //and then pass the direction with it
            //But in our case it is a rectilinear skybox so we have to do this conversion
            float2 DirToRectilinear(float3 dir)
            {
                float x = atan2(dir.z, dir.x); //This value is going to be from -TAU/2 to TAU/2
                //Normalizing it to 0 to 1
                x = x / TAU;//this will give us values from -0.5 to 0.5
                x = x + 0.5; //Now this is going to be between 0 to 1

                float y = dir.y;//this value is going to be -1 to 1 and we will normalize it from 0 to 1
                y = y * 0.5 + 0.5;// This will make it from 0 to 1

                return float2(x, y);
            }

            fixed3 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, DirToRectilinear(i.viewDir));//this will create a seam in the scene

                fixed4 col = tex2Dlod(_MainTex, float4(DirToRectilinear(i.viewDir), 0, 0));
                
                return col;
            }
            ENDCG
        }
    }
}
