/*
 *  CategoryHack.h
 *  PlainOAuth
 *
 *  Created by Greg on 8/15/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

// There's an issue where the linker will strip out necessary code if a .m file
// contains nothing but category implementations. Including this at the top of
// any such file should fix the problem.
#define CATEGORY_HACK(name)       \
@interface CategoryHack##name      \
- (void) foo;                       \
@end                                 \
@implementation CategoryHack##name    \
- (void) foo { }                       \
@end
