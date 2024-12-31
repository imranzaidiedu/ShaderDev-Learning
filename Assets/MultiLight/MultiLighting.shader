Shader "Unlit/MultiLighting"
{
    Properties
    {
        _RockAlbedo ("Rock Albedo", 2D) = "white" {}
        [NoScaleOffset] _RockNormals ("Rock Normals", 2D) = "bump" {}
        [NoScaleOffset] _RockHeight ("Rock Height", 2D) = "gray" {}
        [NoScaleOffset] _DiffuseIBL ("Diffuse IBL", 2D) = "black" {}
        [NoScaleOffset] _SpecularIBL ("Specular IBL", 2D) = "black" {}
        _Gloss("Gloss", Range(0, 1)) = 1
        _Color("Color", Color) = (1,1,1,1)
        _AmbientLight("Ambient Light", Color) = (0,0,0,0)
        _NormalIntensity("Normal Intensity", Range(0, 1)) = 1
        _SpecIBLIntensity("Specular IBL Intensity", Range(0, 1)) = 1
        _DisplacementStrength("Displacement Strength", Range(0, 0.2)) = 0
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
