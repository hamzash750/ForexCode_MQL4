//+------------------------------------------------------------------+
//|                                               Trading Manger.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICNUM  20131111

input double Lots          = 0.01;
input double TakeProfit       = 0;
input double StopLoss         = 0;
input double TralingTakeProfit         = 0;
input double TralingStopLoss         = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double CurrentOpenBodyPrice;
double CurrentCloseBodyPrice;
double CurrentHighWickPrice;
double CurrentLowWickPrice;
double LastOpenBodyPrice;
double LastCloseBodyPrice;
double LastHighWickPrice;
double LastLowWickPrice;
int  ticket, total;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   findCurrentLastCandelPrices();
   currentTotalOrder();
   firstOrder();
   openOrder();
   calculatedCurrentStopLossProfit();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openOrder()
  {

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol())
        {
         if(Ask>LastHighWickPrice)
           {
            openBuyOrder();
           }
         else
            if(Ask<LastLowWickPrice)
              {
               openSellOrder();
              }
        }

     }


  }
//+------------------------------------------------------------------+
//|
void firstOrder()
  {
   if(total<1)
     {
      if(Ask>LastHighWickPrice)
        {
         openBuyOrder();
        }
      else
         if(Ask<LastLowWickPrice)
           {
            openSellOrder();
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openBuyOrder()
  {
   Print(" Buy Condition");
   ticket = OrderSend(Symbol(),OP_BUY, Lots,Ask,3,initialStopLoss("Buy"),initialTakeProfit("Buy"),"Follow Trend",MAGICNUM,0,Blue);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openSellOrder()
  {
   Print(" Sell Condition");
   ticket = OrderSend(Symbol(),OP_SELL, Lots,Ask,3,initialStopLoss("Sell"),initialTakeProfit("Sell"),"Follow Trend",MAGICNUM,0,Red);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void currentTotalOrder()
  {

   total = OrdersTotal();
  }
//+------------------------------------------------------------------+
void findCurrentLastCandelPrices()
  {
   CurrentOpenBodyPrice=Open[0];
   CurrentCloseBodyPrice=Close[0];
   CurrentHighWickPrice=High[0];
   CurrentLowWickPrice=Low[0];
   LastOpenBodyPrice=Open[1];
   LastCloseBodyPrice=Close[1];
   LastHighWickPrice=High[1];
   LastLowWickPrice=Low[1];

  }
//+------------------------------------------------------------------+
double initialStopLoss(string orderType)
  {
   if(orderType=="Buy")
     {
      return LastLowWickPrice;
     }
   else
     {
      return LastHighWickPrice;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double initialTakeProfit(string orderType)
  {
   if(orderType=="Buy")
     {
      return (Ask+TakeProfit);
     }
   else
     {
      return (Bid-TakeProfit);
     }
  }
//+------------------------------------------------------------------+
void calculatedCurrentStopLossProfit()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        {
         bool res;
         if(OrderType()==OP_BUY)
           {
            double stopLoss;
            double takeProfit;
            if(Ask>OrderOpenPrice())
              {
               if(OrderProfit()<1)
                 {
                  stopLoss=(OrderStopLoss()+TralingStopLoss);
                 }
               else
                 {
                  stopLoss=(Ask-TralingStopLoss);
                 }
               takeProfit=(Ask+TralingTakeProfit);
              }
            else
              {
               stopLoss=(OrderOpenPrice()-StopLoss);
               takeProfit=(OrderOpenPrice()+TakeProfit);
              }
            res=  OrderModify(OrderTicket(),OrderOpenPrice(),LastLowWickPrice,takeProfit,0,Blue);
           }
         else
            if(OrderType()==OP_SELL)
              {
               double stopLoss;
               double takeProfit;
               if(Ask<OrderOpenPrice())
                 {
                  if(OrderProfit()>1)
                    {
                     stopLoss=(OrderStopLoss()-TralingStopLoss);
                    }
                  else
                    {
                     stopLoss=(Ask+TralingStopLoss);
                    }
                  takeProfit=(Ask-TralingTakeProfit);
                 }
               else
                 {
                  stopLoss=(OrderOpenPrice()+StopLoss);
                  takeProfit=(OrderOpenPrice()-TakeProfit);
                 }

               res=   OrderModify(OrderTicket(),OrderOpenPrice(),LastHighWickPrice,takeProfit,0,Green);

              }
         if(!res)
            Print("Error in OrderModify. Error code=",GetLastError());
         else
            Print("Order modified successfully.");
        }

     }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  }
//+------------------------------------------------------------------+
