Shader "Unlit/FirstUnlitShaderTriangleWaves"
{
    Properties
    {
        _ColorA("Color A", Color) = (0,0,0,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0, 1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
        //Range is just like we have in unity, a slider from first value to the second
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

            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;
            
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
                o.uv = v.uv;
                return o;
            }

            //As inverse lerp is not provided by default, so we are writing our own
            float InverseLerp(float startValue, float endValue, float inputValue)
            {
                return (inputValue - startValue)/(endValue-startValue);
            }
            
            fixed4 frag (Interpolators i) : SV_Target
            {
                //On https://www.desmos.com/calculator, try this formula abs(x*2 -1)
                //This formula will give you a shape of a triangle which means the value will go from 1 to 0 to 1
                //The method below is showing the triangle pattern
                float t = abs(frac(i.uv.x * 5) * 2 -1);

                //We can use trigonometry functions to achieve different results
                //e.g
                t = cos(i.uv.x * 25);
                //^This is showing patterns with values going from -1 to 1
                return t;
            }
            ENDCG
        }
    }
}
