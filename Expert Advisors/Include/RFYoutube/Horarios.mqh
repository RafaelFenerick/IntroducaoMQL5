//+------------------------------------------------------------------+
//|                                                     Horarios.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHorarios
  {
protected:
   
   string m_inicio;
   string m_termino;
   string m_encerramento;

public:
   void CHorarios(string inicio, string termino, string encerramento);
   void ~CHorarios();
   
   bool HorarioEntrada();
   bool HorarioFechamento();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHorarios::CHorarios(string inicio,string termino,string encerramento)
  {
   m_inicio = inicio;
   m_termino = termino;
   m_encerramento = encerramento;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHorarios::~CHorarios(void)
  {
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHorarios::HorarioEntrada(void)
  {
   datetime atual = TimeCurrent();
   datetime inicio = StringToTime(TimeToString(atual, TIME_DATE) + " " + m_inicio);
   datetime termino = StringToTime(TimeToString(atual, TIME_DATE) + " " + m_termino);
   
   return atual >= inicio && atual < termino;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHorarios::HorarioFechamento(void)
  {
   if(m_encerramento=="")
      return false;
      
   datetime atual = TimeCurrent();
   datetime encerramento = StringToTime(TimeToString(atual, TIME_DATE) + " " + m_encerramento);
   
   return atual >= encerramento;
  }
//+------------------------------------------------------------------+
