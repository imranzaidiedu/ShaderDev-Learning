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
        Tags
        {
            "RenderType"="Transparent"//This is for tagging purposes for post-processing effects 
            "Queue" = "Transparent"//This is an actual order the things going to be render in
            //^So changing this will change the render order of this object
        }

        Pass
        {
            //////Back face culling://////
            //This means the backface of the object on which this shader is applied will not be rendered. So Cull means reduction of somthing
            //We can tell shader to cull front faces, back faces or both
            //And by default, we see that backface is culled for objects and to turn that on/off for front/back faces, we use
            //Cull Back
            //Cull Front
            //Cull Off
            
            Cull Off
            
            //////Depth Buffer://////
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
            
            
            //////Render queue://////
            //In Unity's built-in Render pipeline, there is an order in which different types of geometry is rendered
            //1. Skybox, 2. Opaque/geometry, 3. Transparent (which groups all additive and transparent stuff),
            //4. Overlays (like Lens flares etc) 
            
            ZWrite Off//We are turning off the depth buffer for this shader to be able to see it
            
            
            //////ZTest//////
            //There are other things that you can do with the depth buffer
            //As we have turned off to write to the depth buffer by turning it off above (ZWrite Off) but it still reads from
            //the depth buffer, so when this object goes behind an opaque model, that part disappears but sometimes you want
            //to show that even if that is behind an opaque object. To achieve this, we use ZTest which is set to LEqual by
            //default which means less than and equal to. 
            //ZTest means that how testing should work out when you are presented with depth buffer with some value when reading
            
            //ZTest LEqual (default) which means that if the depth of this object is less than or equal to the depth already written 
            //into the depth buffer then show it otherwise don't
            
            //ZTest Always//This will show this object even if it's behind an opaque object means it doesn't care of the depth buffer
            
            //ZTest GEqual//This will show the object only if it's behind of something, not in front of something. An example of it's
            //use is when we want to show a character behind something like an outline of it, we use this
            
            //////Blending Modes//////
            //Blending is normally calculated like below
            //src*A + dst*B
            //Or
            //src*A + dst*B
            //src is source and dst is destination

            //Additive blending is just adding two colors. Let see how it will look like
            //we set A = 1 and B = 1, and add src and dst, which will give us
            //src*1 + dst*1 = src + dst
            
            Blend One One //This means we are setting A = 1 and B = 1
            
            //Multiplicative blending
            //For this, we will be multiplying source with destination
            //To achieve that, we need to set A = dst and B = 0, which will give us
            //src*dst + 0 which is multiplying the src and dst
            
            //Blend DstColor Zero //This means we are setting A = DstColor(Destination color) and B = 0
            
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
                float xOffset = cos(i.uv.y * TAU * 8) * 0.01;
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;
                
                return t * (abs(i.normal.y) < 0.999);
                //(* (abs(i.normal.y) < 0.999)) this part is just to remove the top and bottom of the cylinder to show
                //the powerup effect
            }
            ENDCG
        }
    }
}
