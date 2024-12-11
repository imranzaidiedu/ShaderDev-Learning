Shader "Unlit/FirstUnlitShaderUV"
{
    Properties
    {
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
            
            struct MeshData 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv; //Passing through as it is
                return o;
            }
            
            fixed4 frag (Interpolators i) : SV_Target
            {
                return float4(i.uv, 0, 1);//this is generating this -> float(uv.x, uv.y, 0, 1)
            }
            ENDCG
        }
    }
}
