- (NSDictionary *)temperatureInfo:(NSString *)unit {
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:@""];
    return @{@"weatherString": s};
}

- (int)currentConditionCode {
    return 0;
}

- (UIImage *)getImageForCondition:(NSInteger)conditionCode style:(int)style {
    return nil;
}

- (NSMutableAttributedString *)stringForWeatherImage:(UIImage *)weatherImg withPrefix:(NSString *)prefixString {
    NSString *base = prefixString ? prefixString : @"";
    return [[NSMutableAttributedString alloc] initWithString:base];
}
