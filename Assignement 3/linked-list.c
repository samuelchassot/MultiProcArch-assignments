// Linked list struct
typedef struct node {
    int val;
    struct node *next;
    int to_remove;
    omp_lock_t lock;
} node_t;

/* This function inserts a new given element at the right position of a given linked list.
 * It returns 0 on a successful insertion, and -1 if the list already has that value.
 */
int insert(node_t *head, int val) {
    node_t *previous, *current = NULL;
    current = head;
    omp_set_lock(&current->lock);

    while (current && current->val < val) {
        if (previous){
            omp_unset_lock(&previous->lock);
        }
        previous = current;
        current  = current->next;
        omp_set_lock(&current->lock);
    }

    if (current && current->val == val) { // This value already exists!
        omp_unset_lock(&previous->lock);
        omp_unset_lock(&current->lock);
        return -1;
    }
    
    // Here is the right position to insert the new node.
    node_t *new_node;
    new_node = malloc(sizeof(node_t));
    new_node->val = val;
    new_node->next = current;
    new_node->to_remove = 0;
    omp_init_lock(&new_node->lock);

    previous->next = new_node;
    omp_unset_lock(&previous->lock);
    omp_unset_lock(&current->lock);
    return 0;
}

/* This function removes the specified element of a given linked list.
 * The value of that element is returned if the element is found; otherwise it returns -1.
 */
int delete(node_t *head, int val) {
    node_t *previous, *current;

    if (head->next == NULL) { // The list is empty.
        return -1;
    }

    previous = head;
    current = head->next;
    omp_set_lock(&previous->lock);
    omp_set_lock(&current->lock);
    while (current) {
        if (current->val == val) {
            previous->next = current->next;
            current->to_remove = 1; // Another system component will free this node later
            omp_unset_lock(&previous->lock);
            omp_unset_lock(&current->lock);
            return val;
        }
        omp_unset_lock(&previous->lock);
        previous = current;
        current  = current->next;
        omp_set_lock(&current->lock);

    }
    omp_unset_lock(&previous->lock);
    omp_unset_lock(&current->lock);
    return -1;
}


/* This function searches for a specified element in a given linked list.
 * It returns zero if the element is found; otherwise it returns -1.
 */
int search(node_t *head, int val) {
    node_t *current = head->next;

    while (current) {
        if (current->val == val) {
            return 0;
        }
        current  = current->next;
    }

    return -1;
}
