Shader "Unlit/Assignments/AsgnHealthbarShader"
{
    Properties
    {
        _StartColor("StartColor", Color) = (1,0,0,1)
        _EndColor("EndColor", Color) = (0,1,0,1)
        _FillAmount ("FillAmount", Range(0, 1)) = 1
        _StartingMargin ("StartingMargin", Range(0, 1)) = 0.2
        _EndingMargin ("EndingMargin", Range(0, 1)) = 0.8
        _HealthBarTex ("HealthbarTexture", 2D) = "white" {}
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
            float _FillAmount;
            float _StartingMargin;
            float _EndingMargin;
            bool _IsBending;

            sampler2D _HealthBarTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 sampleUV = float2(_FillAmount, i.uv.y);
                fixed4 col = tex2D(_HealthBarTex, sampleUV);

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
