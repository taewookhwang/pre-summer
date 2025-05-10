const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const SubCategory = require('./SubCategory');
const Category = require('./Category');

const Service = sequelize.define('Service', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  shortDescription: {
    type: DataTypes.STRING(255),
    allowNull: true,
    field: 'short_description'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  basePrice: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    field: 'base_price'
  },
  unit: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: '회'
  },
  duration: {
    type: DataTypes.INTEGER, // Duration in minutes
    allowNull: false
  },
  categoryId: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'category_id',
    references: {
      model: Category,
      key: 'id'
    }
  },
  subcategoryId: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'subcategory_id',
    references: {
      model: SubCategory,
      key: 'id'
    }
  },
  thumbnail: {
    type: DataTypes.STRING,
    allowNull: true
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    field: 'is_active'
  }
}, {
  timestamps: true,
  tableName: 'services'
});

// Define associations
Service.belongsTo(Category, { foreignKey: 'categoryId', as: 'category' });
Service.belongsTo(SubCategory, { foreignKey: 'subcategoryId', as: 'subcategory' });
Category.hasMany(Service, { foreignKey: 'categoryId' });
SubCategory.hasMany(Service, { foreignKey: 'subcategoryId' });

module.exports = Service;