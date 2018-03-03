//+------------------------------------------------------------------+
//|                                           InversaoMediaMovel.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
Utilização do indicador MediaMovel para criação de um indicador
de reversão da média móvel
*/

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Superior
#property indicator_label1  "Superior"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Inferior
#property indicator_label2  "Inferior"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

//--- indicator buffers
double         SuperiorBuffer[];
double         InferiorBuffer[];

int handlemediamovel; // Manipulador do indicador MediaMovel
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SuperiorBuffer,INDICATOR_DATA); // Definição do array SuperiorBuffer como buffer do indicador Superior
   SetIndexBuffer(1,InferiorBuffer,INDICATOR_DATA); // Definição do array InferiorBuffer como buffer do indicador Inferior
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159); // Definição dos símbolos gráficos dos indicadores
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   
   
   handlemediamovel = iCustom(_Symbol, _Period, "MediaMovel", 20); // Inicialização do manipulador com período 20
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
   double MediaArray[];
   CopyBuffer(handlemediamovel, 0, 0, rates_total, MediaArray); // Cópia do Buffer 0 do indicador MediaMovel para o array MediaArray
   
   // Varredura de todas as velas não calculadas
   for(int i=MathMax(20, prev_calculated); i<rates_total; i++)
   {  
      // Zerando os valores dos buffers inicialmente
      SuperiorBuffer[i] = EMPTY_VALUE;
      InferiorBuffer[i] = EMPTY_VALUE;
      
      // Em caso de inversão para baixo, o indicador Superior recebe valor igual a máxima do candle
      if(MediaArray[i-1] > MediaArray[i] && MediaArray[i-2] <= MediaArray[i-1])
         SuperiorBuffer[i] = high[i];
      
      // Em caso de inversão para cima, o indicador Inferior recebe valor igual a mínima do candle
      if(MediaArray[i-1] < MediaArray[i] && MediaArray[i-2] >= MediaArray[i-1])
         InferiorBuffer[i] = low[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
