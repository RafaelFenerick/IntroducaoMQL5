//+------------------------------------------------------------------+
//|                                                MediaMovelRSI.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "CMTrade Tecnologia LTDA"
#property link      "https://www.cmtrade.com.br"
#property version   "1.00"
#property icon      "..\\ico.ico"
#property description ""
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot Candles
#property indicator_label1  "Candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrLime,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---
#define VERMELHO 0
#define VERDE 1
#define PRETO 2
//--- input parameters
input int                  Periodo     = 26;          // Período (média móvel)
input ENUM_MA_METHOD       Metodo      = MODE_SMA;    // Método (média móvel)
input ENUM_APPLIED_PRICE   Preco       = PRICE_CLOSE; // Preço aplicado (média móvel)
input int                  PeriodoRSI  = 14;          // Período (RSI)
input ENUM_APPLIED_PRICE   PrecoRSI    = PRICE_CLOSE; // Preço aplicado (RSI)
input double               SupLimRSI   = 70;          // Limite superior (RSI)
input double               InfLimRSI   = 30;          // Limite inferior (RSI)
//--- indicator buffers
double         CandlesBuffer1[];
double         CandlesBuffer2[];
double         CandlesBuffer3[];
double         CandlesBuffer4[];
double         CandlesColors[];
//---
double         MediaBuffer[];
double         RSIBuffer[];
//---
int            media_handle;
int            rsi_handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CandlesBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,CandlesBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,CandlesBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,CandlesBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,CandlesColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,MediaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,RSIBuffer,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(CandlesBuffer1, true);
   ArraySetAsSeries(CandlesBuffer2, true);
   ArraySetAsSeries(CandlesBuffer3, true);
   ArraySetAsSeries(CandlesBuffer4, true);
   ArraySetAsSeries(CandlesColors, true);
   ArraySetAsSeries(MediaBuffer, true);
   ArraySetAsSeries(RSIBuffer, true);
   
   media_handle = iMA(_Symbol, _Period, Periodo, 0, Metodo, Preco);
   
   rsi_handle = iRSI(_Symbol, _Period, PeriodoRSI, PrecoRSI);
   
   if(media_handle==INVALID_HANDLE || rsi_handle==INVALID_HANDLE)
      return INIT_FAILED;
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---   
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   int copiar = MathMin(rates_total, rates_total - prev_calculated + 1);
   
   if(CopyBuffer(media_handle, 0, 0, copiar, MediaBuffer)<=0) 
      return 0;
   if(CopyBuffer(rsi_handle, 0, 0, copiar, RSIBuffer)<=0) 
      return 0;
   
   for(int i=copiar-1; i>=0; i--)
     {
      CandlesBuffer1[i] = open[i];
      CandlesBuffer2[i] = high[i];
      CandlesBuffer3[i] = low[i];
      CandlesBuffer4[i] = close[i];
      
      CandlesColors[i] = PRETO;
      
      if(i>=rates_total-1) continue;
      
      if(RSIBuffer[i] <= InfLimRSI && MediaBuffer[i] > MediaBuffer[i+1]) 
         CandlesColors[i] = VERDE;
      if(RSIBuffer[i] >= SupLimRSI && MediaBuffer[i] < MediaBuffer[i+1]) 
         CandlesColors[i] = VERMELHO;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
