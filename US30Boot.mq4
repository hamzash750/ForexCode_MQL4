//+------------------------------------------------------------------+
//|                                                         Boot.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICNUM  20131111
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void start()
  {
   Print("Tick . . .  .  . . . . .  . . .");
   Print("RSI . . .  .  . . . . .  . . ."+iRSI(Symbol(),0,14,PRICE_CLOSE,0));
   if(IsNewCandle())
     {
      Print("New Candel Open........");
     }
   int  ticket, total;
   double CurrentOpenBodyPrice=Open[0];
   double CurrentCloseBodyPrice=Close[0];
   double CurrentHighWickPrice=High[0];
   double CurrentLowWickPrice=Low[0];
   double LastOpenBodyPrice=Open[1];
   double LastCloseBodyPrice=Close[1];
   double LastHighWickPrice=High[1];
   double LastLowWickPrice=Low[1];
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);
   calculatedStopLoss(MAGICNUM,CurrentLowWickPrice,LastHighWickPrice,LastLowWickPrice,LastHighWickPrice);
   total = OrdersTotal();
   if(total<1)
     {
      if(Ask>LastHighWickPrice)
        {
         Print(" Buy Condition");
         ticket = OrderSend(Symbol(),OP_BUY, 0.01,Ask,3,LastLowWickPrice,(Ask+43),"Double SMA Crossover",MAGICNUM,0,Blue);
        }
      else
         if(Ask<LastLowWickPrice)
           {
            Print(" Sell Condition");
            ticket = OrderSend(Symbol(),OP_SELL, 0.01,Ask,3,LastHighWickPrice,(Bid-43),"Double SMA Crossover",MAGICNUM,0,Blue);
           }
     }

//BreakEven(MAGICNUM);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailOrder()
  {
   Print(" TrailOrder Condition");
   Print("Current OrderTicket    "+OrderTicket());
   int ticket = 0;
   double tStopLoss = NormalizeDouble(OrderStopLoss(), Digits); // Stop Loss
   Print("Current tStopLoss    "+tStopLoss);
   Print("Current OrderOpenPrice    "+OrderOpenPrice());
   Print("Current OrderTakeProfit    "+OrderTakeProfit());

   RefreshRates();
   if(OrdersTotal()>0)
     {
      if(OrderType()==OP_BUY)
        {
         ticket = OrderModify(OrderTicket(),OrderOpenPrice(),tStopLoss,OrderTakeProfit(),0,Blue);
        }
      if(OrderType()==OP_SELL)
        {
         ticket = OrderModify(OrderTicket(),OrderOpenPrice(),tStopLoss,OrderTakeProfit(),0,Red);
        }
     }
  }
//+------------------------------------------------------------------+
bool BreakEven(int MN)
  {
   Print("BreakEven");
   int Ticket;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      Print("i ====   "+i);
      int TrailingStop=50;
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if(Bid-OrderOpenPrice()>Point*TrailingStop)
        {
         if(OrderStopLoss()<Bid-Point*TrailingStop)
           {
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStop,Digits),OrderTakeProfit(),0,Blue);
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
           }
        }
     }

   return(Ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime NewCandleTime = TimeCurrent();
bool IsNewCandle()
  {
   if(NewCandleTime == iTime(Symbol(), 0, 0))
      return false;
   else
     {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
     }
  }



//+------------------------------------------------------------------+
double calculatedStopLoss(int MN,double currentLowWick,double currentHighWick,double lastCandelLowWick,double lastcandlehighWick)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      Print(" Current Low Wick   ="+currentLowWick);
      Print(" Current Stop Loss  ="+OrderStopLoss());
      if(Ask==Ask)
        {
         double differnce=OrderOpenPrice()-OrderStopLoss();
         double removeloss=differnce-10;
         Print("differnce   ="+differnce);
         Print("Remove value   ="+removeloss);
         if(differnce>10)
           {
            bool res;
            if(OrderType()==OP_BUY)
              {

               double stopLoss=(OrderStopLoss()+removeloss);
               if(stopLoss<=currentLowWick)
                 {

                  Print(" Current StopLoss   ="+stopLoss);
                  res = OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,OrderTakeProfit(),0,Blue);
                 }
               else
                 {
                  res = OrderModify(OrderTicket(),OrderOpenPrice(),lastCandelLowWick,OrderTakeProfit(),0,Blue);
                 }
              }
            if(OrderType()==OP_SELL)
              {
               double stopLoss=(OrderStopLoss()-removeloss);

               Print(" Current StopLoss   ="+stopLoss);
               if(stopLoss>=currentHighWick)
                 {
                  res = OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,OrderTakeProfit(),0,Red);
                 }
               else
                 {
                  res = OrderModify(OrderTicket(),OrderOpenPrice(),lastcandlehighWick,OrderTakeProfit(),0,Red);
                 }

              }
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
           }
         else
           {
            Print("Order Tarling.");
            bool res;
            if(OrderType()==OP_BUY)
              {
               double stopLoss=(OrderOpenPrice()+10);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,OrderTakeProfit(),0,Blue);
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  double stopLoss=(OrderOpenPrice()-10);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,OrderTakeProfit(),0,Green);

                 }
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
           }
        }

     }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   return(0.01);
  }
//+------------------------------------------------------------------+
