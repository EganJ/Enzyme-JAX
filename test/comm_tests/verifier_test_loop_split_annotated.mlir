
module {

  func.func @commSendF(%rank : i32, %tag: i32, %msg :!llvm.ptr<1>, %size :i64) {
    return
  }

  func.func @commRecvF(%rank : i32, %tag: i32, %size: i64) {
    return
  }

  func.func @main(%a : tensor<2x2xf32>) -> tensor<i32> {

    comm.split {
      %msg = comm.simple_msg tensor<2x2xf32>
      %msg3 = comm.simple_msg tensor<2x2xf32>
      comm.branch [1, 4] enter {
        comm.split {
          %msg2 = comm.simple_msg tensor<i32>
          comm.branch [1] enter {
            %step = stablehlo.constant dense<1> : tensor<i32>
            comm.send %msg2 %step : tensor<i32>
          } loop {
          } reenter {
            %step2 = stablehlo.constant dense<1> : tensor<i32>
          } exit {
            %step2 = stablehlo.constant dense<1> : tensor<i32>
          }
          comm.branch [4] enter {
            %start = stablehlo.constant dense<0> : tensor<i32>
            %lim = stablehlo.constant dense<5> : tensor<i32>
            %step = comm.recv %msg2 : tensor<i32>
            %w, %z = stablehlo.while(%iterArg = %a, %iterArg_0 = %start) : tensor<2x2xf32>, tensor<i32>
            cond {
              %9737 = stablehlo.compare  LT, %iterArg_0, %lim,  SIGNED : (tensor<i32>, tensor<i32>) -> tensor<i1>
              stablehlo.return %9737 : tensor<i1>
            } do {
              %next = stablehlo.add %iterArg, %iterArg : tensor<2x2xf32>
              %ni = stablehlo.add %iterArg_0, %step : tensor<i32>
              stablehlo.return %next, %ni : tensor<2x2xf32>, tensor<i32>
            }
            comm.send %msg %w : tensor<2x2xf32>
          }
        }          
        %tens = comm.recv %msg : tensor<2x2xf32>
        // .. do something with tensor and then rebroadcast it
        comm.send %msg3 %tens : tensor<2x2xf32>
      }
      comm.branch [2] enter {
        ^start:
        %tens = comm.recv %msg3  : tensor<2x2xf32>
      }
    }
    %tmp = stablehlo.constant dense<0> : tensor<i32>
    return %tmp : tensor<i32>
  }
}