//
//  AUIFoundationMacro.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/20.
//

#ifndef AUIFoundationMacro_h
#define AUIFoundationMacro_h

#import "AVTheme.h"
#import "AVLocalization.h"

#define AUIFoundationLocalizedString(key)  AVGetString(key, @"AUIFoundation")
#define AUIFoundationColor(key)  AVGetColor(key, @"AUIFoundation")
#define AUIFoundationColor2(key, opacity)  AVGetColor2(key, opacity, @"AUIFoundation")
#define AUIFoundationImage(key)  AVGetImage(key, @"AUIFoundation")
#define AUIFoundationCommonImage(key)  AVGetCommonImage(key, @"AUIFoundation")


#endif /* AUIFoundationMacro_h */
