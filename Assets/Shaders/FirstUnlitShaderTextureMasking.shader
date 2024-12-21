Shader "Unlit/FirstUnlitShaderTextureMasking"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rock ("Rock", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        
        //Random Question
        //Is there such a thing as single channel texture or are we always getting RGBA?
        //There is such thing as single channel texture, not all of them are supported on
        //all platforms though and some of them are only available as like a render texture
        //rather than texture data. So, in simple words, yes, there are tons of different
        //texture format that you can use 
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
            #define TAU 6.28318530718

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Rock;
            sampler2D _Pattern;

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;
                float4 moss = tex2D(_MainTex, topDownProjection);
                float4 rock = tex2D(_Rock, topDownProjection);
                
                float pattern = tex2D(_Pattern, i.uv).x;

                //to have grass where ever this pattern is white
                //we do following code

                float4 finalColor = lerp(float4(1,0,0,1), moss, pattern);
                //it's a blend between red and moss/grass/the pattern we have supplied

                //So these are sampled in different spaces. Moss is on world space
                //and pattern is on uv space, so if we move the object, the pattern
                //moved with it but the main texture stays where it is

                //Blend between rock and moss
                finalColor = lerp(rock, moss, pattern);
                //both moss and rock are in world space and pattern is in uv space

                return finalColor;
            }
            ENDCG
        }
    }
}
