Shader "Unlit/WavesRipplesVertexOffsetting"
{
    Properties
    {
        _ColorA("Color A", Color) = (0,0,0,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0, 1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
        //Range is just like we have in unity, a slider from first value to the second
        _WaveAmplitude("Wave Amplitude", Range(0, 0.2)) = 0.1
    }
    SubShader 
    {
        Tags
        {
            "RenderType"="Opaque" 
            //"Queue" = "Geometry" //To set the queue opaque, we call it Geometry
        }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;
            float _WaveAmplitude;
            
            struct MeshData 
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
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

                //float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 1);
                // v.vertex.y = wave * _WaveAmplitude;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {   
                float2 uvCentered = i.uv * 2 - 1;
                float radialDistance = length(uvCentered);
                
                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                return wave;
            }
            ENDCG
        }
    }
}