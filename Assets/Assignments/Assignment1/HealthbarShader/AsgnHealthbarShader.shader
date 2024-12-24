Shader "Unlit/Assignments/AsgnHealthbarShader"
{
    Properties
    {
        _StartColor("StartColor", Color) = (1,0,0,1)
        _EndColor("EndColor", Color) = (0,1,0,1)
        _FillAmount ("FillAmount", Range(0, 1)) = 1
        _StartingMargin ("StartingMargin", Range(0, 1)) = 0.2
        _EndingMargin ("EndingMargin", Range(0, 1)) = 0.8
        _HealthBarTex ("HealthBarTexture", 2D) = "white" {}
        
        
        _ShineColor ("Shine Color", Color) = (1,1,1,1)
        _ShineIntensity ("Shine Intensity", Range(0,5)) = 1.0
        _ShineWidth ("Shine Width", Range(0,10)) = 3.0
        _ShineThreshold ("ShineThreshold", Range(0,1)) = 0.2
        _Speed ("Shine Speed", Range(0,10)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            //Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _StartColor;
            float4 _EndColor;
            float4 _ShineColor;
            float _FillAmount;
            float _StartingMargin;
            float _EndingMargin;
            float _ShineIntensity;
            float _ShineWidth;
            float _Speed;
            float _ShineThreshold;

            sampler2D _HealthBarTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float from, float to, float value)
            {
                return (value - from)/(to - from);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 sampleUV = float2(_FillAmount, i.uv.y);
                float4 col = tex2D(_HealthBarTex, sampleUV);

                if (_FillAmount < _ShineThreshold)
                {
                    float shineCenter = frac(_Time.y * _Speed);//setting the shine's center/starting position and keeping just the franctional part according to time by speed
                    float dist = abs(i.uv.x - shineCenter);//spreading shine ob both sides
                    float shineFactor = 1.0 - dist * _ShineWidth;//setting width of the shine
                    shineFactor = saturate(shineFactor);//Clamping the shine within 0 and 1
                    float4 shine = shineFactor * _ShineIntensity * _ShineColor;//multiplying shine by color
                    col.rgb += shine.rgb;//adding shine to the main color
                }
                
                if (i.uv.x > _FillAmount)
                {
                    col = -1;
                }

                clip(col);
                return col;
            }
            ENDCG
        }
    }
}
