Shader "Unlit/FirstUnlitShaderPointBiTrilinearFiltering"
{
    //Point filtering
    //Point filtering gives you kind of minecraft look because it doesn't blend between the colors between each individual pixel,
    //it just goes to the nearest neighbour. This is completely unfiltered texture sampling
    
    //Bilinear filtering
    //Bilinear filtering means that it blends between the colors of each pixel. This filtering is default type. 
    
    //Trilinear filtering
    //Trilinear filtering means that not only does it blend between the pixel smoothly but trilinear means that it also blends
    //between the different mip levels which means we will not get the blurriness issue when looking at a very low angle
    
    //You can look the differences by googling 
    
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rock ("Rock", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
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

                float4 finalColor = lerp(float4(1,0,0,1), moss, pattern);
                finalColor = lerp(rock, moss, pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}
