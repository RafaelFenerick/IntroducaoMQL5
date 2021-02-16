//+------------------------------------------------------------------+
//|                                                   MediaMovel.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
Este indicador calcula a média móvel simples baseada em fechamento
cujo período é determinado como input pelo usuário.
*/

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Media
#property indicator_label1  "Media"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      Periodo = 20; // Período da média

//--- indicator buffers
double         MediaBuffer[]; // Buffer para armazenar valores da média móvel

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MediaBuffer,INDICATOR_DATA); // Definição do array MediaBuffer como buffer do indicador Media
   ArraySetAsSeries(MediaBuffer, true); // Definição do array MediaBuffer como AsSeries
   
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
   ArraySetAsSeries(close, true); // Definição do array close como AsSeries para que os índices sejam condizentes com o array MediaBuffer
   // Varredura de todas as barras ainda não calculadas (incluindo a última, cujo valores é alterado até o fechamento total do candle)
   for(int i=MathMin(rates_total-Periodo, rates_total-prev_calculated); i>=0; i--)
   {
      double media = 0.0;
      //Varredura dos últimos Periodo candles para cálculo da média de determinado período
      for(int j=0; j<Periodo; j++)
      {
         media += close[i+j]; // O índice do array close dá-se como i+j pois os array são AsSeries e, portanto, tem as
                              //iformações armazenadas em ordem de tempo da mais nova para a mais antiga. Assim sendo,
                              //índices maiores detêm as posições mais antigas e são utilizados para cálculo das médias
                              //em índicies menores.
      }
      media /= Periodo; // Divisão pelo tamanho do período para determinação do valor da média
      MediaBuffer[i] = media; // Registro da média no buffer do indicador
   }
//--- return value of prev_calculated for next call
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
