Shader "Unlit/MultiLighting"
{
    Properties
    {
        _RockAlbedo ("Rock Albedo", 2D) = "white" {}
        [NoScaleOffset] _RockNormals ("Rock Normals", 2D) = "white" {}
        _Gloss("Gloss", Range(0, 1)) = 1
        _Color("Color", Color) = (1,1,1,1)
        _NormalIntensity("Normal Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        //Base Pass
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "MyLightingLib.cginc"
            
            ENDCG
        }

        //Add Pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One //src * 1 + dst * 1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "MyLightingLib.cginc"
            
            ENDCG
        }
    }
}
