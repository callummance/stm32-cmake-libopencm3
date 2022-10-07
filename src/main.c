#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/usart.h>
#include <libopencm3/stm32/flash.h>

#define LED_PORT GPIOB
#define LED_PIN GPIO3

void init_clocks(void);
void init_gpio(void);

int main()
{
    // Set clock to 20MHz
    init_clocks();

    // Setup semihosting if required

    rcc_periph_clock_enable(RCC_GPIOB);
    gpio_mode_setup(LED_PORT, GPIO_MODE_OUTPUT, GPIO_PUPD_PULLDOWN, LED_PIN);
    gpio_set_output_options(LED_PORT, GPIO_OTYPE_PP, GPIO_OSPEED_LOW, LED_PIN);

    for (;;)
    {
        gpio_toggle(LED_PORT, LED_PIN);
        for (int32_t i = 0; i <= 1000000; i++)
        {
            __asm__("nop");
        }
    }

    return 1;
}

const struct rcc_clock_scale rcc_clock_config =
    {
        // VCO = 80MHz
        .pllm = 2,
        .plln = 10,
        // Not used
        .pllp = RCC_PLLCFGR_PLLP_DIV7,
        .pllq = RCC_PLLCFGR_PLLQ_DIV2,
        // PLLCLK = 20MHz
        .pllr = RCC_PLLCFGR_PLLR_DIV4,
        // Use 16MHz HSI as PLL source
        .pll_source = RCC_PLLCFGR_PLLSRC_HSI16,
        // AHB prescaler = 1
        .hpre = RCC_CFGR_HPRE_NODIV,
        // APB1 prescaler = 1 -> Timer clocks = 20MHz
        .ppre1 = RCC_CFGR_HPRE_NODIV,
        // APB2 prescaler = 1
        .ppre2 = RCC_CFGR_HPRE_NODIV,
        // Use low power voltage scale
        .voltage_scale = PWR_SCALE2,
        // Enable flash data and instruction cache, set flash latency to 4WS(5 cycles)
        .flash_config = FLASH_ACR_DCEN | FLASH_ACR_ICEN | FLASH_ACR_LATENCY_4WS,
        .ahb_frequency = 20000000,
        .apb1_frequency = 20000000,
        .apb2_frequency = 20000000,
};

void init_clocks(void)
{
    rcc_clock_setup_pll(&rcc_clock_config);
}
