module sign_extend (
    input  [18:0] C,        
    output [31:0] C_sign_extended  
);

    assign C_sign_extended = {{13{C[18]}}, C};

endmodule