import numpy as np

def init_compression_factor():
    pr_min = 0.125
    pr_max = 1
    ppp_max_images = 64

    cf_vieja = np.zeros([ppp_max_images, 100])
    cf_nueva = np.zeros([ppp_max_images, 100])

    for ppp_max in range(1, ppp_max_images):
        cf_min = (1.0 + (ppp_max - 1.0) * pr_min) / ppp_max
        cf_max = 1.0 + (ppp_max - 1.0) * pr_max
        r = pow(cf_max / cf_min, (1.0 / 99.0))

        for ql in range(0,100):
            cf_vieja[ppp_max, ql] = (1.0 / ppp_max) * pow(r, (99.0 - ql))
            cf_nueva[ppp_max, ql] = cf_min * pow(r, (99.0 - ql))

    return cf_vieja, cf_nueva

def calcula_ppp(pr, cf, ql):
    # Voy paso a paso haciendo lo mismo que la función subkernel_perceptual_relevance_to_ppp

    block_width = 40.0 # Para nuestra implementación
    SIDE_MIN = 2 # De lhecodec.comp
    PPP_MAX = 8
    PPP_MIN = 1

    ppp_max_theoric = block_width / SIDE_MIN # Esto es 20

    if (ppp_max_theoric > PPP_MAX): ppp_max_theoric = PPP_MAX # Esto no pasa, lo dejo por documentar

    compression_factor = cf[ppp_max_theoric][ql]

    const1 = ppp_max_theoric - 1.0 # 29
    const2 = ppp_max_theoric * compression_factor

    ppp = ppp_max_theoric if (pr==0) else const2/(1.0+const1 * pr)
    ppp = PPP_MIN if (ppp<PPP_MIN) else ppp
    # Ahora vienen los thresholds de los que hablo
    if (ppp > 6): ppp_return = 8
    elif (ppp >= 4): ppp_return = 4
    elif(ppp >= 1.1): ppp_return = 2
    else: ppp_return = 1

    downsample_width = block_width / ppp_return

    return ppp_return, downsample_width

if __name__ == '__main__':
    # Calculo los cf
    cf_vieja, cf_nueva = init_compression_factor()
    
    # Los posibles PR según ajustaPR son
    pr = [0.0, 0.125, 0.25, 0.5, 1.0]
    
    # QL está fijada en 30 para el código en VULHE
    ql = 30

    # CF para nuestros settings
    print("CF (fórmula vieja): {}".format(cf_vieja[20][30]))
    print("CF (fórmula nueva): {}".format(cf_nueva[20][30]))

    # Ahora vamos a probar cómo sale con cada función
    print("Fórmula Vieja")
    for p in pr:
        ppp, dsw = calcula_ppp(p, cf_vieja, ql)
        print("PR = {}, PPP = {}, downsampling = {}".format(p, ppp, dsw))
    
    print("Fórmula Nueva")
    for p in pr:
        ppp, dsw = calcula_ppp(p, cf_nueva, ql)
        print("PR = {}, PPP = {}, downsampling = {}".format(p, ppp, dsw))
