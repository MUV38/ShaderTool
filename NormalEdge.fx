#define USE_SOBEL 1

Texture2D SceneColorTex;
Texture2D SceneNormalTex;

SamplerState LinearSamp {
  Filter = MIN_MAG_MIP_LINEAR;
  AddressU = Clamp;
  AddressV = Clamp; 
};

float2 Resolution;
float4 EdgeColor = {0, 0, 0, 1};

float2 PixelOffset3x3[3*3] = {
  {-1, -1}, { 0, -1}, { 1, -1},
  {-1,  0}, { 0,  0}, { 1,  0},
  {-1,  1}, { 0,  1}, { 1,  1},
};

#if USE_SOBEL
float SobelWeightV[3*3] = {
  -1, -2, -1,
   0,  0,  0,
   1,  2,  1,
};
float SobelWeightH[3*3] = {
  -1,  0,  1,
  -2,  0,  2,
  -1,  0,  1,
};
#else
float LaplacianWeight[3*3] = {
  -1, -1, -1,
  -1,  8, -1,
  -1, -1, -1,
};
#endif

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
  float EdgeNormal = 0.0f;
  
#if USE_SOBEL
  float3 NormalTotalV = 0.0;
  float3 NormalTotalH = 0.0;

  for(int i=0 ; i<9 ; i++){
    float2 Tex = input.Texcoord + PixelOffset * PixelOffset3x3[i];
    float3 Normal = SceneNormalTex.Sample(LinearSamp, Tex).rgb * 2.0f - 1.0f;
    NormalTotalV += Normal * SobelWeightV[i];
    NormalTotalH += Normal * SobelWeightH[i];
  }
  float EdgeNormalV = dot(abs(NormalTotalV), float3(1, 1, 1)) / 3.0f;
  float EdgeNormalH = dot(abs(NormalTotalH), float3(1, 1, 1)) / 3.0f;
  
  EdgeNormal = sqrt(EdgeNormalV*EdgeNormalV + EdgeNormalH*EdgeNormalH);
  if(EdgeNormal > 0.2f){
    EdgeNormal = 1.0f;
  }else{
    EdgeNormal = 0.0f;
  }
#else
  float3 NormalTotal = 0.0f;
  for(int i=0 ; i<9 ; i++){
    float2 Tex = input.Texcoord + PixelOffset * PixelOffset3x3[i];
    float3 Normal = SceneNormalTex.Sample(LinearSamp, Tex).rgb;
    NormalTotal += Normal * LaplacianWeight[i];
  }
  EdgeNormal = dot(abs(NormalTotal), float3(1, 1, 1)) / 3.0f;

  if(EdgeNormal > 0.2f){
    EdgeNormal = 1.0f;
  }else{
    EdgeNormal = 0.0f;
  }
#endif
  
  float4 SceneColor = SceneColorTex.Sample(LinearSamp, input.Texcoord);
  float4 Color = lerp(SceneColor, EdgeColor, EdgeNormal);

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
