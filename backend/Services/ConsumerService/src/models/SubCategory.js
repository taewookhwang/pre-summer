const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const Category = require('./Category');

const SubCategory = sequelize.define(
  'SubCategory',
  {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    parentId: {
      type: DataTypes.STRING,
      allowNull: false,
      field: 'parent_id',
      references: {
        model: Category,
        key: 'id',
      },
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      field: 'is_active',
    },
  },
  {
    timestamps: true,
    tableName: 'subcategories',
  },
);

// Define associations
SubCategory.belongsTo(Category, { foreignKey: 'parentId', as: 'parentCategory' });
Category.hasMany(SubCategory, { foreignKey: 'parentId', as: 'subcategories' });

module.exports = SubCategory;
