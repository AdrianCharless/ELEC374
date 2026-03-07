module sign_extend (
    input  [18:0] C,           
    input         Cout,        
    output [31:0] C_sign_extended  
);

    wire [31:0] extended;

    assign extended = {{13{C[18]}}, C};

    assign C_sign_extended = Cout ? extended : 32'hz;

endmodule
