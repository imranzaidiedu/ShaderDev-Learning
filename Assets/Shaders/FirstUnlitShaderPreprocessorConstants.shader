Shader "Unlit/FirstUnlitShaderPreprocessorConstants"
{
    Properties
    {
        _ColorA("Color A", Color) = (0,0,0,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0, 1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
        //Range is just like we have in unity, a slider from first value to the second
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

            //This is a preprocessor define
            //Means that any instance of TAU is directly going to be replaced by the value we have defined with it
            //You can define names, macros etc with this
            #define TAU 6.28318530718
            //TAU is a mathematical constant, you can learn more about it on the internet

            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;
            
            struct MeshData 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float t = cos(i.uv.x * TAU * 2);
                //This is remapping from (-1 to 1) to (0 to 1) or viceversa

                t = cos(i.uv.x * TAU * 2) * 0.5 + 0.5;
                //This will shift the range.
                //Now it's going 1 to 0 to 1
                return t;
            }
            ENDCG
        }
    }
}
