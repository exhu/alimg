#include "color_reducer.h"

static int downgrade4lookup[256];

static int downgrade(int a, int targetBitCount) {
    int maxv = ((1 << targetBitCount) - 1);
    // ((a / 255.f) * maxv) / maxv * 255.f
    return a * maxv / 255 * 255 / maxv;
}

static void init_lookups() {
    for(int i = 0; i < 256; ++i) {
        downgrade4lookup[i] = downgrade(i, 4);
    }
}

static int downgrade4444(int a, int c) {
    //return downgrade(a, 4);
    return downgrade4lookup[a];
}

void color_reducer_init(color_reducer * r) {
    init_lookups();
    r->downgr = &downgrade4444;
}


void color_reducer_to_closest(const color_reducer * r, const trgba * src, trgba * dest) {
    for (int i = 0; i < 4; ++i) {
        dest->rgba[i] = r->downgr(src->rgba[i], i);
    }
}


