Shader "Unlit/MultiLighting"
{
    Properties
    {
        _RockAlbedo ("RockAlbedo", 2D) = "white" {}
        _Gloss("Gloss", Range(0, 1)) = 1
        _Color("Color", Color) = (1,1,1,1)
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
