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
                float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);
                
                //At this stage, with some colors, you will see more than two colors
                //This is happening because shader don't natively clamp between 0 and 1,
                //so you need to do that whereever you want to keep a value within a range
                //In out case, the InverseLerp has values ourside of 0 and 1

                //For this, we use Frac function in shader which primarily substract floor value from the value
                //frac = value - floor(value)
                // e.f value = 1.34 => frac(value) => 0.34
                //So frac removes the decimal part of a value and return the fractional part
                t = frac(t);
                //Now this will create repeating pattern and you can check in the scene 
                
                float4 outColor = lerp(_ColorA, _ColorB, t);
                return outColor;
            }
            ENDCG
        }
    }
}
