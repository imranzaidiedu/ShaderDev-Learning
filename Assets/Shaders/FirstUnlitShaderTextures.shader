Shader "Unlit/FirstUnlitShaderTextures"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //^This is how we setup a texture property. This is set to 2D which means the supplied texture will be a
        //2D texture. There are also 3D textures and there are cube maps but we are only work with 2D texture for now
        //_MainTex is a default name for Unity's texture property, usually that contains the color information on
        //the surface
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

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //^variable : ^semantics
                //^uv coordinates are only to pass the data so you can use any name
                //but the semantics will remain the same
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;//optional as we see in editor that it refers to the
            //tiling and offset properties that we see in the editor so we can set these
            //property to set how a texture should be mapped

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //{
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //^This "TRANSFORM_TEX" method takes offset values and offset some input uv coordinates
                //This method takes the _MainTex_ST property which is the name of texture and _ST as a suffix
                //to let the unity program know that it can use these valus to offset and tile accordingly
                //This is totally optional so you can just pass the uv as it is
                //}
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                //^this tex2D() function means that we are gonna pick a color from the texture and the input to
                //this is the sampler (the texture) that we are going to provide with it, in this case its _MainTex
                //and the other parameter is from where do we want to get colors from this texture. So the uv coordinates
                //are usually used for exactly this purpose, for sampling textures. The space we are working with
                //textures are from 0 to 1 which is also known as normalized coordinates
                
                return col;
            }
            ENDCG
        }
    }
}
