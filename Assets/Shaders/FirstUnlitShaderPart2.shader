Shader "Unlit/FirstUnlitShaderPart2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
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

            float4 _Color;
            
            struct MeshData 
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normals;
                return o;
            }
            
            fixed4 frag (Interpolators i) : SV_Target
            {
                //showing model/mesh space normals which is why if we rotate the model, the colors are rotating with it
                return float4(i.normal, 1);
            }
            ENDCG
        }
    }
}
