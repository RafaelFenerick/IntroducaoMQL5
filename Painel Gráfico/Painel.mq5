//+------------------------------------------------------------------+
//|                                                       Painel.mq5 |
//|                                  Copyright 2019, Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Rafael Fenerick"
#property link      "https://www.youtube.com/RafaelFenerick"
#property version   "1.00"

string infos[3] = {"Símbolo", "Cotação", "Posição"};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int delta_x = 10;
   int delta_y = 10;
   int x_size = 200;
   int line_size = 15;
   int y_size = line_size*ArraySize(infos)+10;
   
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
      ObjectSetInteger(0, infos[i], OBJPROP_FONTSIZE, 10);
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
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, name, OBJPROP_TEXT, "-");
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
   ObjectSetString(0, infos[1] + "Valor", OBJPROP_TEXT, DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_LAST), 0));
   ObjectSetString(0, infos[2] + "Valor", OBJPROP_TEXT, posicao);
   
  }
//+------------------------------------------------------------------+
