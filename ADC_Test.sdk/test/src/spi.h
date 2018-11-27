/*
 * spi.h
 *
 *  Created on: Nov 26, 2018
 *      Author: Jacob
 */

#ifndef SRC_SPI_H_
#define SRC_SPI_H_

void spi_init();
void spi_write(uint32_t txAddr, uint32_t txData);
unsigned int spi_read(uint32_t rxAddr);

#endif /* SRC_SPI_H_ */
