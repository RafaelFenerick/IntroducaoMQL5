//+------------------------------------------------------------------+
//|                                              Introdução_MQL5.mq5 |
//|                                  Copyright 2017, Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
Este script exemplifica o cálculo de uma média de 3 períodos 
na posição mais atual, utilizando valores fictícios para tal.
*/

// Struct responsável por armazenar valores de abertura, fechamento,
//máxima e mínima dos candles
struct precos
{
 double abertura;
 double fechamento;
 double maxima;
 double minima;
};

// Função para cálculo do valor médio de um candle.
// Nota-se a utilização do & no parâmetro da função. Isso se deve pois
//o parâmetro é uma struct e não pode ser passado por valor, apenas por referência,
//necessitando do &.
double media(precos &candle)
{
   return (candle.abertura + candle.fechamento + candle.maxima + candle.minima)/4;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   // Array de structs preço de tamanho 3 para armazenar informações dos últimos 3 candles
   precos ultimos_candles[3];
   
   // Alocação de valores aleatórios nas 3 posições do array ultimos_candles para exemplificação
   //do funcionamento do cálculo de média
   ultimos_candles[0].abertura = 10.0;
   ultimos_candles[0].fechamento = 10.5;
   ultimos_candles[0].maxima = 11.0;
   ultimos_candles[0].minima = 9.8;
   
   ultimos_candles[1].abertura = 10.5;
   ultimos_candles[1].fechamento = 10.9;
   ultimos_candles[1].maxima = 11.4;
   ultimos_candles[1].minima = 10.1;
   
   ultimos_candles[2].abertura = 10.9;
   ultimos_candles[2].fechamento = 11.4;
   ultimos_candles[2].maxima = 11.4;
   ultimos_candles[2].minima = 10.6;
   
   // Declaração de variável para armazenamento do somatório dos valores
   //médios dos candles analisados
   double media_3_periodos = 0;
   
   // Varredura em todas as posições do array ultimos_candles
   for(int i=0; i<3; i++)
   {
      // Cálculo do valor médio em cada candle
      media_3_periodos += media(ultimos_candles[i]);
   }
   
   // Divisão pelo número de candles para determinar o valor da média
   media_3_periodos /= 3;
   
   // Exibição do valor da média
   Print(media_3_periodos);
   
  }
//+------------------------------------------------------------------+
