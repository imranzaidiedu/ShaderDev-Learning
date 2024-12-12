Shader "Unlit/FirstUnlitShaderGradient"
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
                //At this stage, we are seeing repeating patterns
                //To get rid of those, we will be using a method in shader called Saturate
                //Saturate makes sure that if the value is less than 0, make it 0 and if it is greater than 1, make it 1
                //Saturate is a built-in function in the shader language itself
                //To see more methods like this, you can go to this link: https://developer.download.nvidia.com/cg/index_stdlib.html
                //That site shows you all of the available mathod and also shows how you can do them manually if you want
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                float4 outColor = lerp(_ColorA, _ColorB, t);
                return outColor;
            }
            ENDCG
        }
    }
}
