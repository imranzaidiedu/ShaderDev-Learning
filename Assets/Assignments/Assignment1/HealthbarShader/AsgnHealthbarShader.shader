Shader "Unlit/Assignments/AsgnHealthbarShader"
{
    Properties
    {
        _StartColor("StartColor", Color) = (1,0,0,1)
        _EndColor("EndColor", Color) = (0,1,0,1)
        _FillAmount ("FillAmount", Range(0, 1)) = 1
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 gradient = lerp(_StartColor, _EndColor, _FillAmount);
                if (i.uv.x > _FillAmount)
                {
                    gradient = 0;
                }
                return gradient;
            }
            ENDCG
        }
    }
}
