import type { Schema, Struct } from '@strapi/strapi';

export interface PostMediaItem extends Struct.ComponentSchema {
  collectionName: 'components_post_media_items';
  info: {
    description: 'A single image in a post carousel';
    displayName: 'Media Item';
  };
  attributes: {
    altText: Schema.Attribute.String &
      Schema.Attribute.SetMinMaxLength<{
        maxLength: 255;
      }>;
    height: Schema.Attribute.Integer;
    image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    sortOrder: Schema.Attribute.Integer &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          max: 9;
          min: 0;
        },
        number
      > &
      Schema.Attribute.DefaultTo<0>;
    width: Schema.Attribute.Integer;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'post.media-item': PostMediaItem;
    }
  }
}
