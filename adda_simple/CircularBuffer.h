/*
Simple circular buffer. 
- Declare with 'RingBuffer myBuffer;' 
- Tweak size with 'define BUFFER_SIZE'
- Buffer is only writable if MORE THAN ONE position is still free
    -> if you need N elements in the buffer at the same time, make the size N+1 
    -> this is due to the implementation of isBufferFull()-method

*/

#include <stdio.h>
// #include <unistd.h>  // for sleep function

#define BUFFER_SIZE 252 // = K + 1
#define K 251

typedef struct {
    short buffer[BUFFER_SIZE];
    int head;
    int tail;
} RingBuffer;


void initializeBuffer(RingBuffer *rb) {
    rb->head = 0;   // this is our writing position
    rb->tail = 0;   // this is our reading position
}

// return a 'true' boolean when the head and tail position are identical
int isBufferEmpty(const RingBuffer *rb) {
    return rb->head == rb->tail;
}

// return a 'true' boolean when the next write operation would crash intop the read index
int isBufferFull(const RingBuffer *rb) {
    return (rb->head + 1) % BUFFER_SIZE == rb->tail;
}

int enqueue(RingBuffer *rb, short value) {
    if (isBufferFull(rb)) {
        //printf("Error: Buffer is full, cannot enqueue.\n");
        return -1;
    }

    rb->buffer[rb->head] = value;
    rb->head = (rb->head + 1) % BUFFER_SIZE;
    return 0;
}

short dequeue(RingBuffer *rb) {
    if (isBufferEmpty(rb)) {
        //printf("Error: Buffer is empty, cannot dequeue.\n");
        return 0;
    }

    short value = rb->buffer[rb->tail];
    rb->tail = (rb->tail + 1) % BUFFER_SIZE;
    return value;
}

/*
int main() {
    RingBuffer myBuffer;
    initializeBuffer(&myBuffer);

    enqueue(&myBuffer, 0);
    enqueue(&myBuffer, 1);
    enqueue(&myBuffer, 2);


    while (1) {
        // Dequeue once every second
        sleep(1);

        if (!isBufferEmpty(&myBuffer)) {
            short msg = dequeue(&myBuffer);
            //printf("Dequeue: %d\n", msg);
        }

        // Ask for new characters to put into the ring buffer
        //printf("Enter a character to enqueue: ");
        short c = getchar();
        while (getchar() != '\n');  // Clear the input buffer

        enqueue(&myBuffer, c);
    }

    return 0;
}
*/
