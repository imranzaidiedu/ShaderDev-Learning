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
            //ZWrite Off
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Health;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Rounded edges
                float2 coords = i.uv;
                coords.x *= 8;

                float2 pointOnLineSeg = float2(clamp(coords.x, 0.5, 7.5), 0.5);

                float sdf = distance(coords, pointOnLineSeg) * 2 - 1;

                clip(-sdf);
                
                //return float4(sdf.xxx, 1);
                
                float healthBarMask = _Health > i.uv.x;

                //1a, 1b
                //float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));//1b
                //float3 healthBarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);
                //float3 bgColor = float3(0,0,0);
                //float3 outColor = lerp(bgColor, healthBarColor, healthBarMask);
                //return float4(outColor, 1);

                //1b, 1c, 1d, 1e
                float3 healthBarColor = tex2D(_MainTex, float2(_Health, i.uv.y));
                if (_Health < 0.2)
                {
                    float flash = cos(_Time.y * 4) * 0.4 + 1;
                    healthBarColor *= flash;
                }
                return float4(healthBarColor * healthBarMask, 1);
                
            }
            ENDCG
        }
    }
}
