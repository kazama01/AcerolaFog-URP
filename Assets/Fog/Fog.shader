Shader "Hidden/URP_SSFog" {
    Properties {
        _BlitTexture ("Blit Texture", 2D) = "white" {}
        _FogColor ("Fog Color", Color) = (1,1,1,0.5)
        _FogDensity ("Fog Density", Float) = 0.1
        _FogOffset ("Fog Offset", Float) = 0.0
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue"="Transparent" "RenderType" = "Transparent" }
        Pass {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
             Cull Off
             Blend Off
             ZTest Off
             ZWrite Off
            HLSLPROGRAM
            #pragma vertex FullScreenVert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
             #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenShaderPass.cs.hlsl"
            
            struct Attributes {
                uint vertexID : SV_VertexID;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _BlitTexture;
            float4 _FogColor;
            float _FogDensity, _FogOffset;
            
            Varyings FullScreenVert(Attributes IN) {
                Varyings OUT;
                OUT.positionCS = GetFullScreenTriangleVertexPosition(IN.vertexID);
                OUT.uv = GetFullScreenTriangleTexCoord(IN.vertexID);
                return OUT;
            }
            
            half4 Frag(Varyings IN) : SV_Target {
                float4 col = tex2D(_BlitTexture, IN.uv);
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, IN.uv);
                depth = Linear01Depth(depth, _ZBufferParams);
                float viewDistance = depth * _ProjectionParams.z;
                
                float fogFactor = (_FogDensity / sqrt(log(2))) * max(0.0f, viewDistance - _FogOffset);
                fogFactor = exp2(-fogFactor * fogFactor);
        
                float4 foggedColor = lerp(_FogColor, col, saturate(fogFactor));
                return foggedColor;
            }
            ENDHLSL
        }
    }
}
