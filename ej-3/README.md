Para este ejercicio utilicé la imagen **subfuzion/netcat** que es basada en Alpine y ya tiene instalado **netcat**.

# Execution

- From this directory run:
> docker build -t ej3-image .
> docker run --network=tp0-base_testing_net ej3-image