Shader "Unlit/FirstUnlitShaderMipmaps"
{
    //A little bit about mipmaps (MIP maps)
    //When you think about a texture, it needs to be loaded into the memory of your GPU in order to draw something with it
    //The important thing to know here is that the texture is not the only thing that gets loaded in the memory, you can make
    //it to just load that but that'd be very bad and this relates to something called mipmaps.
    //What are mipmaps?
    //Mipmaps are that you have copies of your texture but down sampled which will take double memory in your GPU (in worst case 4 times)
    //So mipmaps will be creating multiple downsized versions of the texture. e.g 1x, 0.5x, 0.25x, 0.125x, 0.0625x, 0.03125x.
    //What is the point of having mipmaps?
    //If you think about how shaders work, so if a texture is far away, you have some uv coordinates on some pixels, it actually is
    //going ot take the color of that pixel and output it in a very naive way if you dont have something like this.
    //You can google it to see the difference between mipmapping turned on/off
    
    //How mipmaps are packed?
    //It depends on a lot of factors. Some do it side by side with largest size on the left and make smaller sizes to the right and
    //some do it in a spiral form like fibonacci. It also depends if you have isotropic data or anisotropic data.
    
    //The reason for mipmap is to down sample the texture and then it can sort of guess how far away the texture is by using partial derivatives
    //to figure this out and based on the rate of change of the UVs that you are sampling with, depending on that, it can pick a lower/smaller mip
    //that matches the distance at which you are sampling this in
    
    //There are a lot of stuff that you can add on top of this. The very basic type of mips are the side to side that I explained above is purely
    //distance based, it doesn't really care about angle, it does to some extent but it's isotropic. You can enable anisotropic which stores squished
    //version as well that are squished on some axis, means they are scaled on a specific axis which is useful when you are viewing something from a
    //very low angle. This is what anisotropic filtering is. Anisotropic generally takes more memory. 
    
    //^ a bit about Isotropic and Anisotropic filtering
    
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rock ("Rock", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        _MipSampleLevel("MIP", Float) = 0
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
            float _MipSampleLevel;

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
                //float4 moss = tex2D(_MainTex, topDownProjection);
                
                float4 moss = tex2Dlod(_MainTex, float4(topDownProjection, _MipSampleLevel.xx));
                //^The tex2D cannot be used in the vertex shader but this tex2Dlod can be used in the vertex shader
                
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
