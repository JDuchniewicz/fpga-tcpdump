typedef struct
{
    int addr[$];
    int byteen[$];
    int data[$];
    int burst_len;
    bit[1:0] resp[$];
} avalon_mm_seq_item;

interface avalon_mm_if
#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)
(
    input reset,
    input clock
);

    logic [ADDR_WIDTH-1:0] address;
    logic [(DATA_WIDTH/8)-1:0] byteenable;
    logic read;
    logic [DATA_WIDTH-1:0] readdata;
    logic [1:0] response;
    logic write;
    logic [DATA_WIDTH-1:0] writedata;
    logic waitrequest;
    // bursts

    clocking avalon_mm_master_cb @(posedge clock);
        default input #0 output #0;

        output address;
        output byteenable;
        output read;
        input readdata;
        input response;
        output write;
        output writedata;
        input waitrequest;
    endclocking

    clocking avalon_mm_slave_cb @(posedge clock);
        default input #0 output #0;

        input address;
        input byteenable;
        input read;
        output readdata;
        output response;
        input write;
        input writedata;
        output waitrequest;
    endclocking

    function void clear_bus();
        avalon_mm_master_cb.address    <= '0;
        avalon_mm_master_cb.byteenable <= '0;
        avalon_mm_master_cb.read       <= '0;
        avalon_mm_master_cb.write      <= '0;
        avalon_mm_master_cb.writedata  <= '0;
    endfunction : clear_bus

    function void wait_for_reset();
        if (!reset)
            @(posedge reset);
    endfunction: wait_for_reset

    task write_data(avalon_mm_seq_item item);
        bit [ADDR_WIDTH-1:0] addr_queue[$];
        bit [(DATA_WIDTH/8)-1:0] byteen_queue[$];
        logic [DATA_WIDTH-1:0] data_queue[$];

        addr_queue = { item.addr };
        byteen_queue = { item.byteen };
        data_queue = { item.data };

        while (data_queue.size())
        begin
            @(avalon_mm_master_cb);

            avalon_mm_master_cb.address    <= addr_queue.pop_front();
            avalon_mm_master_cb.write      <= 'd1;
            avalon_mm_master_cb.writedata  <= data_queue.pop_front();
            avalon_mm_master_cb.byteenable <= byteen_queue.pop_front();

            if (avalon_mm_master_cb.waitrequest === 'd1)
                @(negedge avalon_mm_master_cb.waitrequest);

            if (DEBUG)
                $display("writedata = 0x%0h", avalon_mm_master_cb.writedata);

            item.resp.push_back(avalon_mm_master_cb.response); // TODO: handle bursts?
        end

        @(avalon_mm_master_cb);
        avalon_mm_master_cb.write <= 'd0;
        // TODO: response validation
    endtask : write_data

    task read_data(avalon_mm_seq_item item);
        bit [ADDR_WIDTH-1:0] addr_queue[$];
        bit[(DATA_WIDTH/8)-1:0] byteen_queue[$];

        addr_queue = { item.addr };
        byteen_queue = { item.byteen };

        while (item.data.size() < item.burst_len)
        begin
            @(avalon_mm_master_cb);

            avalon_mm_master_cb.address <= addr_queue.pop_front();
            avalon_mm_master_cb.read    <= 'd1;
            avalon_mm_master_cb.byteenable <= byteenable.pop_front();

            if (avalon_mm_master_cb.waitrequest === 'd1)
                @(negedge avalon_mm_master_cb.waitrequest);

            if (DEBUG)
                $display("readdata = 0x%0h, response 0x%0h", avalon_mm_master_cb.readdata, avalon_mm_master_cb.response);

            item.data.push_back(avalon_mm_master_cb.readdata);
            item.resp.push_back(avalon_mm_master_cb.response);
        end

        @(avalon_mm_master_cb);
        avalon_mm_master_cb.read <= 'd0;
    endtask : read_data

endinterface : avalon_mm_if
