Shader "Unlit/FirstUnlitShaderBlendingModes"
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
            //Blending is normally calculated like below
            //src*A + dst*B
            //Or
            //src*A + dst*B
            //src is source and dst is destination

            //Additive blending is just adding two colors. Let see how it will look like
            //we set A = 1 and B = 1, and add src and dst, which will give us
            //src*1 + dst*1 = src + dst
            
            Blend One One //This means we are setting A = 1 and B = 1
            //As soon as we start blending and making things transparent, we start seeing a problem of not
            //seeing the objects behind this object and you will see some sorting issues. This is happening because of depth buffer.
            //What is a depth buffer or Z buffer and how it works? Look on internet
            //There's a lot going on in a depth buffer but in a layman term, it's a big screen space texture where some shaders write
            //a depth value ranging from 0 to 1 and when other shaders want to render they check the depth buffer to see if this fragment/pixel 
            //is behind or in front of the depth buffer and if it's behind the depth buffer, it will not render. You can take an example of
            //of how camera work in unity, the objects that are beyond near and far of a perspective camera, does not gets render. This is
            //not an exact example of depth buffer as in depth buffer, when an OPAQUE object comes in front of another object and is covering the
            //fragments/pixels, the object behind that object or a covered part of the object gets excluded from the depth buffer.
            //So, when we use transparent objects in the scene, the depth buffer does not exclude any object that comes within the camera range
            //which results in high processing when using particles as they are mostly transparent.
            //Another thing, the draw will not be skipped when an object is excluded from depth buffer but the fragments will be discarded very early
            //even before your fragment shader executes, so fragment shader will not execute at all if the object is excluded from the depth buffer
            //To exclude it even from the draw, we use occlusion culling. Will cover that in a separate section.
            //There are two things you can do in depth buffer, you can change the way that it read from the depth buffer and the way that it 
            //writes to the depth buffer 
            
            //So if you have a lot of particles in a scene and it's covering a lot of pixels then it's going to be very heavy on GPU as it'd be
            //doing a lot of processing but if it's a bit far away from the camera and covering a small amount of pixel then it will not cause
            //much problem, that's why you have to be very careful in these kind of situations. This is called fill rates. You have to be careful
            //to not have to high of the fill rates 
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

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
                float xOffset = i.uv.y;
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;
                
                return t;
            }
            ENDCG
        }
    }
}
