Texture2D SceneTex;
Texture2D DepthTex;

float2 ScreenSize;
float DepthThreshold;
float3 EdgeColor = { 0.0f, 0.0f, 0.0f };

SamplerState LinearSamp
{
  Filter = MIN_MAG_MIP_LINEAR;
  AddressU = Clamp;
  AddressV = Clamp;
};

struct VS_INPUT
{
  float3 Position  : POSITION;
  float2 Texcoord  : TEXCOORD;
  float3 Normal    : NORMAL;
  float4 Color     : COLOR;
  float3 Tangent   : TANGENT;
  float3 Bitangent : BITANGENT;
};

struct PS_INPUT
{
  float4 Position  : SV_POSITION;
  float2 Texcoord  : TEXCOORD;
  float3 Normal    : NORMAL;
  float4 Color     : COLOR;
  float3 Tangent   : TANGENT;
  float3 Bitangent : BITANGENT;
};

PS_INPUT VS_Main(VS_INPUT input)
{
  PS_INPUT output = (PS_INPUT)0;
  
  output.Position = float4(input.Position, 1.0f);
  output.Texcoord = input.Texcoord;
  output.Normal = input.Normal;
  output.Color = input.Color;
  output.Tangent = input.Tangent;
  output.Bitangent = input.Bitangent;
  
  return output;
}

float4 PS_Main(PS_INPUT input) : SV_TARGET
{
  float4 Color = float4(EdgeColor, 1.0f);

  float2 PixelOffset = 1.0f / ScreenSize;
  
  float Z  = DepthTex.Sample(LinearSamp, input.Texcoord).r;
  float Z1 = DepthTex.Sample(LinearSamp, saturate(input.Texcoord + float2( PixelOffset.x,  PixelOffset.y))).r;
  float Z2 = DepthTex.Sample(LinearSamp, saturate(input.Texcoord + float2(-PixelOffset.x,  PixelOffset.y))).r;
  float Z3 = DepthTex.Sample(LinearSamp, saturate(input.Texcoord + float2( PixelOffset.x, -PixelOffset.y))).r;
  float Z4 = DepthTex.Sample(LinearSamp, saturate(input.Texcoord + float2(-PixelOffset.x, -PixelOffset.y))).r;

  if(abs(Z - Z1) < DepthThreshold &&
     abs(Z - Z2) < DepthThreshold &&
     abs(Z - Z3) < DepthThreshold &&
     abs(Z - Z4) < DepthThreshold)
  {
    Color = SceneTex.Sample(LinearSamp, input.Texcoord);
  }


  return Color;
}

technique11 Main
{
  pass p0
  {
    SetVertexShader(CompileShader(vs_5_0, VS_Main()));
    SetHullShader(NULL);
    SetDomainShader(NULL);
    SetGeometryShader(NULL);
    SetPixelShader(CompileShader(ps_5_0, PS_Main()));
  }
};
