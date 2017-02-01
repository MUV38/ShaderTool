Texture2D SceneColorTex;

float2 Resolution;

SamplerState LinearSamp
{
  Filter = MIN_MAG_MIP_LINEAR;
  AddressU = Clamp;
  AddressV = Clamp;
};

float2 PixelOffset3x3[3*3] = {
  {-1, -1}, { 0, -1}, { 1, -1},
  {-1,  0}, { 0,  0}, { 1,  0},
  {-1,  1}, { 0,  1}, { 1,  1},
};

float LaplacianWeight[] = {
  -1, -1, -1,
  -1,  8, -1,
  -1, -1, -1
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
  float2 PixelOffset = 1.0f / Resolution;
  float4 Color = float4(0, 0, 0, 1);
  
  for(int i=0 ; i<9 ; i++){
    float2 Tex = input.Texcoord + PixelOffset3x3[i]*PixelOffset;
    float4 SceneColor = SceneColorTex.Sample(LinearSamp, Tex);
 
    Color.rgb += SceneColor.rgb * LaplacianWeight[i];
  }
  
  Color = saturate(Color);

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
