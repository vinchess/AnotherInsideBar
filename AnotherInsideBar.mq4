//+------------------------------------------------------------------+
//|                                             AnotherInsideBar.mq4 |
//|                                       Copyright 2017 Vincent Lim |
//|                                            vince.lim@outlook.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017 Vincent Lim"
#property link      "vince.lim@outlook.com"
#property version   "1.00"
#property strict

input int            magicNumber    =  123456; //Magic Identifier
input double         lotSize        =  0.01; //Lot Multiplier

double lot = 0.0;
double buy = 0.0;
double sell = 0.0;
int barsTotal = 0;
int range = 0;
int innerrange = 0;

int init(){
   return(0);
}

int deinit(){
   return(0);
 }


void OnTick(){
   trail();
   if(iBars(Symbol(),PERIOD_CURRENT) > barsTotal){
      //ClosePending();
      if(isInsideBar()){
         ClosePending();
         setup(checkDirection());
      }
      barsTotal = iBars(Symbol(),PERIOD_CURRENT);
   }
}

int range(){
   int currencyMulti = (int)MathPow(10,Digits);
   int diff = (int)(High[2]*currencyMulti)-(Low[2]*currencyMulti);
   return diff;
}

int innerrange(){
   int currencyMulti = (int)MathPow(10,Digits);
   int diff = 0;
   if(Open[2]>Close[2]){
      diff = (int)(Open[2]*currencyMulti)-(Close[2]*currencyMulti);
   }else{
      diff = (int)(Close[2]*currencyMulti)-(Open[2]*currencyMulti);
   }
   
   return diff;
}

bool isInsideBar(){
   if(High[2] > High[1] && Low[2] < Low[1]){
      return true;
   }else{
      return false;
   }
}

int checkDirection(){

   if(Open[2]>Close[2])
      return OP_SELLSTOP;
   else if(Open[2]<Close[2])
      return OP_BUYSTOP;
   else
      return ERR_TRADE_NOT_ALLOWED;
}

void setup(int direction){

   range = range();
   innerrange = innerrange();
   double bsl = 0.0;
   double btp = 0.0;
   double ssl = 0.0;
   double stp = 0.0;
   bool res;
   lot = NormalizeDouble(((AccountBalance() * 0.01)*lotSize),2);
   
   if(lot>100){ lot=100; }
   
   if(innerrange > (range/2)){
      sell = NormalizeDouble(Low[2]-((range*0.1)*Point),Digits);
      ssl = NormalizeDouble(Low[2]+((range*0.2)*Point),Digits);
      stp = NormalizeDouble(Low[2]-((range*0.8)*Point),Digits);
      res = OrderSend(Symbol(),OP_SELLSTOP,lot,sell,0,ssl,stp,"Sell Order",magicNumber,0,Green);
      buy = NormalizeDouble(High[2]+((range*0.1)*Point),Digits);
      bsl = NormalizeDouble(High[2]-((range*0.2)*Point),Digits);
      btp = NormalizeDouble(High[2]+((range*0.8)*Point),Digits);
      res = OrderSend(Symbol(),OP_BUYSTOP,lot,buy,0,bsl,btp,"Sell Order",magicNumber,0,Green);
   }
   
   
   /*if(direction == OP_SELLSTOP){
      sell = NormalizeDouble(Low[1]-((range*0.1)*Point),Digits);
      ssl = NormalizeDouble(Low[1]+((range*0.2)*Point),Digits);
      stp = NormalizeDouble(Low[1]-((range*0.8)*Point),Digits);
      bool res = OrderSend(Symbol(),OP_SELLSTOP,lot,sell,0,sl,tp,"Sell Order",magicNumber,0,Green);
   }else if(direction == OP_BUYSTOP){
      buy = NormalizeDouble(High[1]+((range*0.1)*Point),Digits);
      bsl = NormalizeDouble(High[1]-((range*0.2)*Point),Digits);
      btp = NormalizeDouble(High[1]+((range*0.8)*Point),Digits);
      bool res = OrderSend(Symbol(),OP_BUYSTOP,lot,buy,0,sl,tp,"Sell Order",magicNumber,0,Green);
   }*/

}

void ClosePending(){
   int cnt = OrdersTotal();
   for(int i=cnt-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
         if(OrderMagicNumber()==magicNumber){
            if(OrderType() != OP_BUY  || OrderType() != OP_SELL){
               int tix = OrderTicket();
               
               int check = 132;
               while(check == ERR_MARKET_CLOSED){
                  bool res = OrderDelete(tix);
                  if(!res){
                     Print("OrderDelete error, code=",GetLastError());
                     check = GetLastError();
                  }
                  else
                     Print("Order successfully deleted.");
               }
            }
         }
      }
   }
}

void trail(){
      
      int trail = (range*0.2)+5;
      int cnt = OrdersTotal();
      bool res = false;
      for(int i=cnt-1;i>=0;i--){
         if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
           if(OrderMagicNumber()==magicNumber){
              int type = OrderType();
              
                     if(type == OP_BUY){
                       if(Bid-OrderOpenPrice()>Point*trail){
                           //if(OrderStopLoss()<Bid-Point*trail){// || OrderStopLoss()==trailingStop){
                              Print("Modify Buy");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                              res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()+Point*trail,Digits),
                                       OrderTakeProfit(),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                           }
                        //}
                     }
                     else if(type == OP_SELL){
                        if(OrderOpenPrice()-Ask>Point*trail){
                          //if(OrderStopLoss()>Ask+Point*trail){// || OrderStopLoss()==trailingStop){
                              Print("Modify Sell");
                              //bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*trailingStop,Digits),
                                       //OrderTakeProfit(),0,Blue);
                              res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderStopLoss()-Point*trail,Digits),
                                       OrderTakeProfit(),0,Blue);
                              if(!res)
                                 Print("Error in OrderModify. Error code=",GetLastError());
                              else
                                 Print("Order modified successfully.");
                           }
                        //}
                     }
                  
               
            }
         }
      }
   
}