Shader "Unlit/AsgnHealthBarSol"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Health;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float healthBarMask = _Health > i.uv.x;

                float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));//1b
                float3 healthBarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);
                float3 bgColor = float3(0,0,0);
                float3 outColor = lerp(bgColor, healthBarColor, healthBarMask);
                return float4(outColor, 1);
            }
            ENDCG
        }
    }
}
