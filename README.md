# Autocorrelation / Convolution FIR (Verilog)

This repo provides a parameterized Verilog module that can compute either **correlation** or **convolution** using the same shift-register structure (newest sample at index 0). The design supports a programmable delay (`DELAY`) and 16-bit signed samples, with 2× data width accumulation.

## Files
- `src/Autocorrelation.v` — main RTL, parameterized `SIZE`, `DELAY`, `DATA_WIDTH`.
- `sim/bin.mem` — example memory file for coefficients or stimuli (optional).
- `src/tb_autocorrelation.v` — example testbench (optional).

## How it works

With the shift-register storing **newest sample at index 0**:
- **Convolution**:  
  \( y[n] = \sum_{j=0}^{N-1} h[j]\;x[n-j] \)  
  Implemented by **natural coefficient order** and MAC: `shift_reg[j] * coeff_mem[j]`.

- **Correlation**:  
  \( r[n] = \sum_{j=0}^{N-1} x[n-j]\;h[N-1-j] \)  
  Implemented by either:
  1) flipping the coefficient index in the MAC: `coeff_mem[N-1-j]`, or  
  2) storing coefficients **reversed** at load time and keeping MAC natural.

A sample delay `DELAY` is applied on the **signal path** as `shift_reg[j + DELAY]`.

## Problems Faced & Resolutions

1. **Convolution vs Correlation Confusion**  
   - *Problem:* Using `shift_reg[j] * coeff_mem[j]` with newest-at-0 indexing was assumed to be correlation.  
   - *Resolution:* Normally this is convolution, but in our design the shift-register direction effectively flipped the signal, so the same formula produced correlation output.
   - *Note:* in Our case we not flipped the coefficents beacuse our shift regiter which work as delay line also flip the incoming signal. Due to which we obtained correlation Output not Convolution. If we use register in order newest sample on last buffer and oldest sample on first buffer then we will obtained convolution output
2. **Accumulator Not Cleared**  
   - *Problem:* `acc` not reset each cycle produced growing sums.  
   - *Resolution:* Set `acc = 0;` (blocking) before the MAC loop inside the sequential block.

3. **Extra `end` / Syntax**  
   - *Problem:* A stray `end` after the loader caused compile errors.  
   - *Resolution:* Remove the extra `end`. Ensure blocks are properly nested.


4. **Where to Apply Delay**  
   - *Problem:* DELAY mistakenly considered on coefficient index.  
   - *Resolution:* Delay belongs on the **signal path**: use `shift_reg[j + DELAY]`.

## Parameters
- `SIZE` — number of taps/samples (default 256)  
- `DELAY` — correlation/convolution sample offset (default 48)  
- `DATA_WIDTH` — input data width (default 16)

