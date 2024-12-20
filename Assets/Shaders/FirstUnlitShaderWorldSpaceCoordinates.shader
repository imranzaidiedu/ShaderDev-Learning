Shader "Unlit/FirstUnlitShaderWorldSpaceCoordinates"
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
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                //o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
                //unity_ObjectToWorld is equals to UNITY_MATRIX_M
            //1://o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1));////Object to world
                //^we are transforming this to local space to world space by multiplying it
                //to model matrix
                //When you do some matric multiplication where you transform some three dimension
                //vector, you usually pass a float4 or vector4 in that where the 4th component
                //depending on if the 4th component is zero, it's gonna transform as vector or direction
                //but if it's one, it's gonna transform as a position, means it's gonna take offset into
                //account. If it's 0, offset is not going to be included, it's just going to be the orientation and scale
                //But in this case above, it's a position
                
                
                //We use mul() because it has the advantage that we flip the arguments to transpose
                //the matrix

                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);//Object to world
                //^removed casting from 1: as it's working fine like this as well
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;
                
                //this is showing colors according to the world space
                //return float4(i.worldPos.xyz,1);

                return float4(topDownProjection, 0,1);
            }
            ENDCG
        }
    }
}
