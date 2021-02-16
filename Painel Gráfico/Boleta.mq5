//+------------------------------------------------------------------+
//|                                                       Boleta.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//---
#include <Trade/Trade.mqh>
//--- input parameters
input double   Volume=1.0;
//---
string infos[3] = {"Símbolo", "Cotação", "Posição"};
string botoes[3] = {"Compra", "Venda", "Fechar"};

CTrade   negocio;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int delta_x = 20;
   int delta_y = 20;
   int x_size = 250;
   int line_size = 30;
   int button_size = 160;
   int y_size = line_size*(ArraySize(infos) + ArraySize(botoes)) +10;
   
   //--- Criar o painel
   
   // Background
   if(!ObjectCreate(0, "Background", OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return(INIT_FAILED);
   
   ObjectSetInteger(0, "Background", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "Background", OBJPROP_XDISTANCE, delta_x);
   ObjectSetInteger(0, "Background", OBJPROP_YDISTANCE, y_size + delta_y);
   ObjectSetInteger(0, "Background", OBJPROP_XSIZE, x_size);
   ObjectSetInteger(0, "Background", OBJPROP_YSIZE, y_size);
   
   ObjectSetInteger(0, "Background", OBJPROP_BGCOLOR, clrYellow);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_COLOR, clrBlack);
   
   // Criar campos
   for(int i=0; i<ArraySize(infos); i++)
     {
      if(!ObjectCreate(0, infos[i], OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);
         
      ObjectSetInteger(0, infos[i], OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, infos[i], OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, infos[i], OBJPROP_XDISTANCE, delta_x + 5);
      ObjectSetInteger(0, infos[i], OBJPROP_YDISTANCE, delta_y - 5 + y_size - i*line_size);
      
      ObjectSetInteger(0, infos[i], OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, infos[i], OBJPROP_FONTSIZE, 14);
      ObjectSetString(0, infos[i], OBJPROP_TEXT, infos[i]);
     }
     
   // Iniciar valores
   for(int i=0; i<ArraySize(infos); i++)
     {
      string name = infos[i] + "Valor";
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);
         
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, delta_x + x_size - 5);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, delta_y - 5 + y_size - i*line_size);
      
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 14);
      ObjectSetString(0, name, OBJPROP_TEXT, "-");
     }
     
   // Criar botões
   for(int i=0; i<ArraySize(botoes); i++)
     {
      if(!ObjectCreate(0, botoes[i], OBJ_BUTTON, 0, 0, 0))
         return(INIT_FAILED);
         
      ObjectSetInteger(0, botoes[i], OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, botoes[i], OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, botoes[i], OBJPROP_XDISTANCE, delta_x + x_size/2 - button_size/2);
      ObjectSetInteger(0, botoes[i], OBJPROP_YDISTANCE, delta_y - 5 + y_size - (i + ArraySize(infos))*line_size);
      
      ObjectSetInteger(0, botoes[i], OBJPROP_XSIZE, button_size);
      ObjectSetInteger(0, botoes[i], OBJPROP_YSIZE, line_size-5);
      
      ObjectSetInteger(0, botoes[i], OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, botoes[i], OBJPROP_FONTSIZE, 14);
      ObjectSetString(0, botoes[i], OBJPROP_TEXT, botoes[i]);
     }
   
   ChartRedraw();
   
   OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //--- Remover o painel do gráfico
   ObjectDelete(0, "Background");
   for(int i=0; i<ArraySize(botoes); i++)
     ObjectDelete(0, botoes[i]);
   for(int i=0; i<ArraySize(infos); i++)
     ObjectDelete(0, infos[i]);
   for(int i=0; i<ArraySize(infos); i++)
     ObjectDelete(0, infos[i]+"Valor");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //--- Atualizar as informações do painel
   string posicao = "Nenhuma";
   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         posicao = "Comprado";
      else
         posicao = "Vendido";
     }
   ObjectSetString(0, infos[0] + "Valor", OBJPROP_TEXT, _Symbol);
   ObjectSetString(0, infos[1] + "Valor", OBJPROP_TEXT, DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits));
   ObjectSetString(0, infos[2] + "Valor", OBJPROP_TEXT, posicao);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Sleep(100);
      if(sparam=="Compra")
        {
         negocio.Buy(Volume, _Symbol, 0, 0, 0, "Boleta");
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        }
      if(sparam=="Venda")
        {
         negocio.Sell(Volume, _Symbol, 0, 0, 0, "Boleta");
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        
        }
      if(sparam=="Fechar")
        {
         negocio.PositionClose(_Symbol);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        
        }
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
